#!/bin/bash
BASE_URL="http://localhost:8383"
create_item() { local item=$1; echo "Creating item: $item"; curl -s -X GET "$BASE_URL/create?item=$item"; echo; }
read_items() { echo "Reading all items..."; curl -s -X GET "$BASE_URL/read"; echo; }
update_item() { local id=$1; local item=$2; echo "Updating item $id: $item"; curl -s -X GET "$BASE_URL/update?id=$id&item=$item"; echo; }
delete_item() { local id=$1; echo "Deleting item $id"; curl -s -X GET "$BASE_URL/delete?id=$id"; echo; }
create_item "TestItem1"
create_item "TestItem2"
read_items
update_item 1 "UpdatedItem1"
read_items
delete_item 1
read_items
delete_item 2
read_items
