# JsonToJavaConverter
A small ruby script which helps you to create java classes to hold the data from a json response

# Motivation
While developing android apps you usually have to create Java classes to handle a response from a Rest Api.
Personally I find this really boring, so I made a ruby script to create these classes

# Usage
I recommend to paste this script in your project models folder.
Basically, you paste a sample json in a file named as the Java class you want to create.
For example, if you are going to create a Java class named LoginResponse.java, just paste the sample Json in a file named LoginResponse and run the script.

In this repo, I'm adding a Json in the file named WeatherResponse. A concrete example of use is:
./json_to_java.rb --parse WeatherResponse --privacy private -c --package com.example.model

# Script parameters
The script can handle some parameters:

# --parse FileName1,FileName2,FileName3 (without spaces)
The files to be parsed, this parameter is mandatory, and as you can see, you can parse several files in a single run.

# --privacy [public|private]
The privacy of the fields, the script will left it empty if nothing was inserted

# --package [com.example.model]
If detected, the script add the package line at the beginning of the java file created.

# -c
This turns the name of the fields from snake_case to camelCase.

