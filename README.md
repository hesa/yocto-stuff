# Yocto Stuff

*misc Yocto related stuff*

# Background

In my work with Yocto and compliance I need to be to quickly set up a
Yocto build to use as a test bench for [Compliance Utils](https://github.com/vinland-technology/compliance-utils)

# Preparations

## Install Compliance Utils

Assuming you want to install [Compliance Utils](https://github.com/vinland-technology/compliance-utils) in `opt` in your home directory:

```
cd
mkdir opt
cd opt
git clone https://github.com/vinland-technology/compliance-utils.git
```

## Adding Compliance Utils to your path

```
PATH=${PATH}:~/opt/compliance-utils/bin
```

# Setting up Yocto and running yoga

## Build a yocto image from scratch

```
install-yocto.sh
```

## 

```
run-yoga.sh
```
