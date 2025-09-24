package com.sparta.mg.libraryproject2.model.repositories;

import com.sparta.mg.libraryproject2.model.entities.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BookRepository extends JpaRepository<Book, Integer> {
}