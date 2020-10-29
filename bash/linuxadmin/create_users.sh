# List of possible groups to add users to
groups=("temp" "staff" "developers" "admin")

# Keep track of which group we're adding a user to
i=0

# Take in the first argument as the file to open and loop through each line of the file
while IFS= read -r line; do
        # Assign the user a group
        group=${groups[$i]}
        username=${line//[[:blank:]]/}
        username=${username//-/}
        username=${username:0:20}

        echo "Creating a user and assign them a group : sudo useradd -m -c \"$line\" -s/bin/bash -G $group $username"
        sudo useradd -m -c "$line" -s/bin/bash -G $group $username -p Linux2020

        # Require the username to update the default password when signing in
        sudo passwd -e $username

        echo "Creating a user file in their group : sudo mkdir groups/$group/$username"
        sudo mkdir /home/ubuntu/groups/$group/$username

        # Grant users of admin group sudo permissions
        if [ $group == "admin" ]
        then
                echo "Granting sudo priveleges to $username  : sudo usermod -a -G sudo $username"
                sudo usermod -a -G sudo $username
        fi

        # Set developer shells to C shell
        if [ $group == "developers" ]
        then
                echo "Setting C shell as default for developer $username : sudo chsh --shell /bin/sh $username"
                sudo chsh --shell /bin/sh $username
        fi

        # Increment value so that next user is in a different group (even distribution across each group, % 4 handles going back to the first value
        let "i++"
        i=$((i%4))
done < "$1"