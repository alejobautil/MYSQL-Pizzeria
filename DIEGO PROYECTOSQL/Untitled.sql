/*Como funciona las variables OUT Dentro de un procredimiento*/
/*Un procedimiento que, con base a el codigo del cliente me traiga su respectivo nombre completo

en 1 variable.*/

desc persona;
 
set @resultado="";
 
DELIMITER //

CREATE PROCEDURE buscar_nombre_cliente(IN v_id INT, OUT resultado VARCHAR(150)) 

BEGIN 

    SELECT concat(persona.nombre, ' ', persona.apellido) INTO resultado from cliente 

	JOIN persona on persona.id=cliente.id where cliente.id=v_id;

END //

DELIMITER ;
 
call buscar_nombre_cliente(5, @resultado);

select @resultado;
 
DROP procedure buscar_nombre_cliente;
 