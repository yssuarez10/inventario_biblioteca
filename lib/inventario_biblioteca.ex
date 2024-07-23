defmodule InventarioBiblioteca do
  @moduledoc """
  Documentation for `InventarioBiblioteca`.
  """

  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(library) do
    library
  end

  def list_users(users) do
    users
  end

  def search_by_available(library) do
    if Enum.find(library.available, &(&1.available == true)) do
      library
    end
  end

  def search_by_isbn(library, isbn) do
    if Enum.find(library.isbn, &(&1.isbn == isbn)) do
      library
    end
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def run do
    loop(InventarioBiblioteca)
  end

  defp loop(inventario_biblioteca) do
    IO.puts("""
    Gestor de Biblioteca
    1. Agregar libros al stock
    2. Listar libros disponibles
    3. Buscar libros disponibles por ISBN
    4. Registrar usuario
    5. Listar usuarios
    6. Solicitar libro
    7. Devolver libro
    8. Listar libros prestados por usuario.
    9. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el titulo del libro: ")
        title = IO.gets("") |> String.trim()
        IO.write("Ingrese el autor: ")
        author = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()
        book = {title, author, isbn, true}
        inventario_biblioteca = add_book(Book, book)
        loop(inventario_biblioteca)

      2 ->
        search_by_available(inventario_biblioteca)
        loop(inventario_biblioteca)

      3 ->
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()
        search_by_isbn(Book, isbn)
        loop(inventario_biblioteca)

      4 ->
        IO.write("Ingrese el ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese el nombre del usuario: ")
        name = IO.gets("") |> String.trim() |> String.to_integer()
        user = {name, id, []}
        inventario_biblioteca = add_user(User, user)
        loop(inventario_biblioteca)

      5 ->
        list_users(inventario_biblioteca)
        loop(inventario_biblioteca)

      6 ->
        IO.write("Ingrese el ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim() |> String.to_integer()
        inventario_biblioteca = borrow_book(Book, User, id, isbn)
        loop(inventario_biblioteca)

      7 ->
        IO.write("Ingrese el ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim() |> String.to_integer()
        inventario_biblioteca = return_book(Book, User, id, isbn)
        loop(inventario_biblioteca)

      8 ->
        IO.write("Ingrese el ID del usuario: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        inventario_biblioteca = books_borrowed_by_user(User, id)
        loop(inventario_biblioteca)

      9 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(inventario_biblioteca)
    end
  end
end
