package com.sparta.mg.libraryproject2.controller;

import com.sparta.mg.libraryproject2.model.entities.Author;
import com.sparta.mg.libraryproject2.model.repositories.AuthorRepository;
import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class AuthorWebController {

    private final AuthorRepository authorRepository;

    @Autowired
    public AuthorWebController(AuthorRepository authorRepository) {
        this.authorRepository = authorRepository;
    }

    @GetMapping("/web/authors")
    public String getAllAuthors(Model model) {
        model.addAttribute("authors", authorRepository.findAll());
        return "authors";
    }

    @GetMapping("/web/author/{id}")
    //@PreAuthorize("hasRole('ROLE_USER')")
    public String getAuthor(Model model, @PathVariable Integer id) {
        model.addAttribute("author",authorRepository.findById(id).orElse(null));
        return "author";
    }

    @GetMapping("/web/author/edit/{id}")
    //@PreAuthorize("hasRole('ROLE_ADMIN')")
    public String getAuthorToEdit(Model model, @PathVariable Integer id) {
        model.addAttribute("authorToEdit",authorRepository.findById(id).orElse(null));
        return "author-edit-form";
    }

    @PostMapping("/web/updateAuthor")
    public String updateAuthor(@ModelAttribute("authorToEdit") Author editedAuthor) {
        authorRepository.saveAndFlush(editedAuthor);
        return "edit-success";
    }
}
