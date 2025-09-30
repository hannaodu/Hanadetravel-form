#!/bin/bash

echo "📦 Packaging Lambda function..."

# Go to lambda directory
cd lambda

# Install production dependencies only
npm install --production

# Create the zip file with only necessary files
zip -r function.zip index.js node_modules/

echo "✅ Lambda function packaged successfully!"
echo "📁 function.zip created"

# Show the zip file size
ls -lh function.zip
