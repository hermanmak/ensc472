function [  ] = mailer( email )
%MAILER Summary of this function goes here
%   Detailed explanation goes here

setpref('Internet','E_mail',UserName);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',UserName);
setpref('Internet','SMTP_Password',passWord);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
emailto = email; % recipient's email
sendmail(emailto, 'HELP', 'Please save me');

end

