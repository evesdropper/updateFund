pip install --target ./package requirements.txt
cd package
zip -r ../deploy.zip .
cd ..
zip deploy.zip lambda_function.py
zip deploy.zip auth/*
