#!/bin/bash

# Check if mailutils is installed
if ! command -v mail > /dev/null 2>&1; then 
    echo "Mailutils is not installed."
    echo "Installing Mailutils..."
    
    sudo apt update && sudo apt install mailutils -y

    echo "Mailutils installed successfully."
fi

# Configuration
LOG_FILE="etl_pipeline.log"
PYTHON_SCRIPT="E-commerce_ETL.py" 
EMAIL="abdelrahmangamal287@gmail.com"

echo "--------------------------------------------------" >> "$LOG_FILE"
echo "$(date): ETL Process Started" >> "$LOG_FILE"

# Run ETL script and capture errors
if python3 "$PYTHON_SCRIPT" >> "$LOG_FILE" 2>&1; then
    echo "$(date): ✅ ETL Process Completed Successfully" >> "$LOG_FILE"
else
    echo "$(date): ❌ ETL Process Failed" >> "$LOG_FILE"
    
    echo "ETL Process Failed. Check logs: $LOG_FILE" | mail -s "ETL Failure Alert" "$EMAIL"
fi

echo "--------------------------------------------------" >> "$LOG_FILE"

