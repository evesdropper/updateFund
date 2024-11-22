package_directory="./package/"
if [[ -d $package_directory ]]; then
    if [[ -n "$(ls -A $package_directory)" ]]; then
        rm -r $package_directory
    fi
else 
    mkdir package
fi
pip install --target ./package -r requirements.txt

cd package
zip -r ../deploy.zip .
cd ..
zip deploy.zip lambda_function.py
zip deploy.zip config.yml
zip deploy.zip auth/*
