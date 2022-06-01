SELECT author, title, 
    ROUND(IF(author = "Булгаков М.А.", price * 1.1, IF(author = "Есенин С.А.", price *1.05, price * 1)), 2) AS new_price
FROM book;

/* Для каждой книги из таблицы book установим скидку следующим образом: если количество книг меньше 4, то скидка будет составлять 50% от цены, в противном случае 30%.*/
SELECT title, amount, price, 
    IF(amount<4, price*0.5, price*0.7) AS sale
FROM book;

/*Посчитать, количество различных книг и количество экземпляров книг каждого автора , хранящихся на складе.  Столбцы назвать Автор, Различных_книг и Количество_экземпляров соответственно.*/
SELECT author AS Автор, 
	COUNT(title) AS Различных_книг, 
	SUM(amount) AS Количество_экземпляров
FROM book
GROUP BY author

/*Посчитать стоимость всех экземпляров каждого автора без учета книг «Идиот» и «Белая гвардия». В результат включить только тех авторов, у которых суммарная стоимость книг (без учета книг «Идиот» и «Белая гвардия») более 5000 руб. Вычисляемый столбец назвать Стоимость. Результат отсортировать по убыванию стоимости.*/
SELECT author, 
    ROUND(SUM(price*amount), 2) AS Стоимость
FROM book
WHERE title NOT IN ("Идиот", "Белая гвардия")
GROUP BY author
HAVING SUM(amount * price) > 5000
ORDER BY SUM(amount * price) DESC

/*Вывести информацию (автора, название и цену) о  книгах, цены которых меньше или равны средней цене книг на складе. Информацию вывести в отсортированном по убыванию цены виде. Среднее вычислить как среднее по цене книги.*/
SELECT author, title, price
FROM book
WHERE price <= (
    SELECT AVG(price)
    FROM book)
ORDER BY price DESC

/*Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы всех книг на складе стало столько, сколько сейчас есть экземлпяров самой широкопредставленной книги. Вывести название книги, ее автора, текущее количество экземпляров на складе и количество заказываемых экземпляров книг. Последнему столбцу присвоить имя Заказ. В результат не включать книги, которые заказывать не нужно.*/
SELECT title, 
    author, 
    amount, 
    (SELECT MAX(amount) FROM book) - amount AS Заказ 
FROM book
HAVING Заказ > 0

/*Create a table*/
CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author VARCHAR(30),
    price DECIMAL(8, 2),
    amount INT
);

/*Вывести информацию (автора, книгу и количество) о тех книгах, количество экземпляров которых в таблице book не дублируется.*/
SELECT author, title, amount
FROM book
WHERE amount IN (
    SELECT amount
    FROM book 
    GROUP BY amount
    HAVING COUNT(amount) = 1
                )

/* Вывести фамилию с инициалами и общую сумму суточных, полученных за все командировки для тех сотрудников, которые были в командировках больше чем 3 раза, в отсортированном по убыванию сумм суточных виде. Последний столбец назвать Сумма.*/
SELECT name, SUM((1 + DATEDIFF(date_last, date_first)) * per_diem) AS Сумма
FROM trip
GROUP BY name
HAVING COUNT(DISTINCT trip_id) > 3
ORDER BY Сумма DESC

/*В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных слкдующим образом записей. Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили одно и то же правило   два и более раз. При этом учитывать все нарушения, независимо от того оплачены они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, потом по номеру машины и, наконец, по нарушению. 
*/  
UPDATE fine, (
                SELECT name, number_plate, violation
                FROM fine
                GROUP BY name, number_plate, violation
                HAVING count(violation) >= 2
                ORDER BY name, number_plate, violation
               ) query_in
SET sum_fine = sum_fine*2
WHERE 
    date_payment is null AND
    fine.name = query_in.name AND
    fine.number_plate = query_in.number_plate AND
    fine.violation = query_in.violation
;

SELECT * 
FROM fine