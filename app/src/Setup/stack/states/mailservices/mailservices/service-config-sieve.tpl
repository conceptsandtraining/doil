require ["fileinto"];
if allof (header :contains "subject" "[%DOMAIN%]") {
    fileinto "%DOMAIN%";
    stop;
}