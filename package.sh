#!/bin/sh

output=""
exit_status=1

test() {
    source ./bin/activate
    output=$(python -c "from lambda_function import scrape; print(scrape())")
    exit_status=$?
    deactivate
}

package() {
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
}

# test then package
test
if [[ $exit_status -eq 0 ]]; then
    OUTPUT_PATTERN="\('[0-9]{4}-[0-9]{1,2}-[0-9]{1,2} [012][0-9]:[0-6][0-9]', [0-9]{1,9}\)"
    if [[ $output =~ $OUTPUT_PATTERN ]]; then
        package
    fi
fi
