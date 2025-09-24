package com.sparta.mg.libraryproject2.exceptions;

public class AuthorNotFoundException extends Exception{
    public AuthorNotFoundException(String name) {
        super("Could not find Author:" + name);
    }
}
