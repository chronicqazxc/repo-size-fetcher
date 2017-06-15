#echo https://github.disney.com/api/v3/repos/$1/$2.git | perl -ne 'print $1 if m!([^/]+/[^/]+?)(?:\.git)?$!' | xargs -I{} curl -s -k https://$3:$4@github.disney.com/api/v3/repos/'{}' | grep -e full_name -e clone_url -e size

#echo https://github.disney.com/api/v3/repos/$1/$2.git | perl -ne 'print $1 if m!([^/]+/[^/]+?)(?:\.git)?$!' | xargs -I{} curl -s -k https://$3:$4@github.disney.com/api/v3/repos/'{}'

echo $1 | perl -ne 'print $1 if m!([^/]+/[^/]+?)(?:\.git)?$!' | xargs -I{} curl -s -k https://$2:$3@github.disney.com/api/v3/repos/'{}'
