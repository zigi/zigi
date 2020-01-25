![IMAGE](https://user-images.githubusercontent.com/117615/69496216-051d1580-0ed0-11ea-9ea5-cf0d9153482c.png)
---

## WHAT IS ZIGI
Zigi is an ISPF Git Interface for z/OS
---

# Some code

```x = docmd('git --version')
  required_version = '2.14.4'
  parse var so.1 'git' 'version' version'_'subversion
  version = strip(version,'B')
  if version < required_version then do
    zs1 = "Your git version is not at the minimum required level"
    zs2 = "Your level    : "version
    zs3 = "Required level: "required_version
    zs4 = 'Press Enter to exit and install the correct version.'
    call do_popup4p
    exit 8
  end```
