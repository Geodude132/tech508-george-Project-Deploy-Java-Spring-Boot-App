package com.sparta.mg.libraryproject2;

import com.sparta.mg.libraryproject2.controller.AuthorWebController;
import com.sparta.mg.libraryproject2.model.entities.Author;
import com.sparta.mg.libraryproject2.model.repositories.AuthorRepository;
import com.sparta.mg.libraryproject2.model.repositories.BookRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Bean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebMvcTest(AuthorWebController.class)
@AutoConfigureMockMvc
public class MVCTests {

    @Autowired
    private MockMvc mockMvc;

//  private AuthorRepository authorRepository;
//

    @Test
    @DisplayName("test Authors Page")
    void testAuthorsPage() throws Exception {
//        Author author = new Author();
//        author.setId(1);
//        author.setFullName("Manish");
//        Mockito.when(authorRepository.findAll()).thenReturn(new ArrayList<>(List.of(author)));

        mockMvc.perform(MockMvcRequestBuilders.get("/web/authors")).andDo(MockMvcResultHandlers.print());
    }
}
