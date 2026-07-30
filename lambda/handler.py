import os 
import boto3
import urllib.parse
from datetime import datetime, UTC

# define the s3 client and dynamodb client module scope
s3=boto3.client('s3')
table=boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    for record in event['Records']:
        bucket=record['s3']['bucket']['name']
        raw_key=record['s3']['object']['key']
        key=urllib.parse.unquote_plus(raw_key)
        size=record['s3']['object']['size']
        etag=record['s3']['object']['eTag']

        response=s3.get_object(Bucket=bucket, Key=key)
        content_type=response['ContentType']
        text=response['Body'].read().decode('utf-8', errors='replace')
        
        lines=text.splitlines()
        item = {
            'doc_id':key,
            'bucket':bucket,
            'size_bytes':size,
            'etag':etag,
            'content_type':content_type,
            'line_count':len(lines),
            'char_count':len(text),
            'word_count':len(text.split()),
            'processed_at':datetime.now(UTC).isoformat()
        }

        if key.endswith('.md'):
            item['heading_count']=sum(1 for ln in lines if ln.strip().startswith('#'))

        table.put_item(Item=item)
        print(f"processed {key}: {item['size_bytes']} bytes, {item['word_count']} words")

    return {'statusCode': 200}