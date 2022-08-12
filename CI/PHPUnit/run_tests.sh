#!/bin/bash

./app/vendor/phpunit/phpunit/phpunit --bootstrap ./app/vendor/autoload.php ./app/tests "$@"