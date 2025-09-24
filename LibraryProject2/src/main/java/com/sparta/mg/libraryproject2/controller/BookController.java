package com.sparta.mg.libraryproject2.controller;

import com.sparta.mg.libraryproject2.exceptions.AuthorNotFoundException;
import com.sparta.mg.libraryproject2.model.entities.Author;
import com.sparta.mg.libraryproject2.model.entities.Book;
import com.sparta.mg.libraryproject2.model.repositories.AuthorRepository;
import com.sparta.mg.libraryproject2.model.repositories.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
public class BookController {
    private final AuthorRepository authorRepository;
    private final BookRepository bookRepository;

    @Autowired
    public BookController(AuthorRepository authorRepository, BookRepository bookRepository) {
        this.authorRepository = authorRepository;
        this.bookRepository = bookRepository;
    }

    @PostMapping("/book")
    public String addBook(@RequestBody Book book) throws AuthorNotFoundException {
        Optional<Author> author = authorRepository.findAuthorByFullName(book.getAuthor().getFullName());
        if (author.isEmpty()) {
            throw new AuthorNotFoundException(book.getAuthor().getFullName());
        } else {
            book.setAuthor(author.get());
            bookRepository.save(book);
            return "book saved";
        }
    }
}
