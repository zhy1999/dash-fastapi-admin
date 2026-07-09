#!/bin/bash
API_KEY="ragflow-aF5rhjLXi5w1OXjkgjG8-OXmIChzhAvcPjnry_PC3tY"
BASE="http://10.208.11.16:1800"
DS="84ce872c686b11f18bbc1f8b5d59c487"

upload_and_parse() {
  local file=$1
  # 1) 上传
  local doc_id=$(curl -s --request POST \
    --url "${BASE}/api/v1/datasets/${DS}/documents" \
    --header "Authorization: Bearer ${API_KEY}" \
    --form "file=@${file}" \
    --form 'run="0"' \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['id'])")
  
  echo "Uploaded: ${file} → ${doc_id}"
  
  # 2) 触发解析
  curl -s --request POST \
    --url "${BASE}/api/v1/documents/ingest" \
    --header "Authorization: Bearer ${API_KEY}" \
    --header 'Content-Type: application/json' \
    --data "{\"doc_ids\":[\"${doc_id}\"],\"run\":1}"
  echo
  echo "Parsing started for ${doc_id}"
}
