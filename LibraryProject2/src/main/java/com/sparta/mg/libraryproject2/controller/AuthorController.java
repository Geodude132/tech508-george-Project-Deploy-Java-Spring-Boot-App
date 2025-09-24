package com.sparta.mg.libraryproject2.controller;

import com.sparta.mg.libraryproject2.model.entities.Author;
import com.sparta.mg.libraryproject2.model.repositories.AuthorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
public class AuthorController {
    private final AuthorRepository authorRepository;

    @Autowired
    public AuthorController(AuthorRepository authorRepository) {
        this.authorRepository = authorRepository;
    }

    // if RequestParam is null return all authors. Else return authors with the name

    @GetMapping("/author/{id}")
    public Optional<Author> getAuthorById(@PathVariable Integer id){
        return authorRepository.findById(id);
    }

    @GetMapping("/authors")
    public List<Author> getAllAuthorsByName(@RequestParam(name = "name",  required = false) String name) {
        List<Author> authors;
        if (name == null) {
            authors = authorRepository.findAll();
        } else {
            authors = authorRepository.findAuthorsByFullName(name);
        }
        return authors;
    }

    @PatchMapping("/author/{id}")
    public Author saveAuthor(@RequestBody Author newAuthor, @PathVariable Integer id) {
        Author author = authorRepository.findById(id).get();
        author.setFullName(newAuthor.getFullName());
        return authorRepository.save(author);
    }
}
