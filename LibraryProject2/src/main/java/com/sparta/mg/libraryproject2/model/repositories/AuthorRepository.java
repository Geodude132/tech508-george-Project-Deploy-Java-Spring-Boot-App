package com.sparta.mg.libraryproject2.model.repositories;

import com.sparta.mg.libraryproject2.model.entities.Author;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AuthorRepository extends JpaRepository<Author, Integer> {

    List<Author> findAuthorsByFullName(String name);
    List<Author> findAuthorsByFullNameStartingWith(String letter);

    Optional<Author> findAuthorByFullName(String fullName);
}