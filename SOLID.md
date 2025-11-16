Notas sobre SOLID:

Single Responsability Principle: solo debe existir una razon para cambiar el codigo. Cuando hay multiples responsabilidades dentro de una clase/modulo
tiende a romperse este principio debido a que cada modulo deberia tener una sola responsabilidad y por esta razon una sola razon de cambio (modificacion de la responsabilidad).

patron fachada, patron proxy.





Open/Closed principle: Una clase/modulo debe estar disenhado para ser extendido, no modificado. Es decir, debe tener la posibilidad de anhadir nuevas funcionalidades
sin producir gran impacto. Los modulos deberian ir de los mas simples(basicos/esenciales) a los mas complejos, siendo estos ultimos hijos del anterior (casos puntuales que lo requieran).

Patron decorador, patron estrategia, patron fabrica.








Liskov substitution principle: Padre deberia ser substituible por el hijo (Modulos y herencia). En otras palabras, los hijos deberian heredar el comportamiento de la clase padre y no modificarlo.






Interface Segretation Principle: Las interfaces que creemos no deben tener metodos que no necesitamos. Separa los metodos en interfaces de acuerdo a la necesidad del cliente.





Dependency Inversion Principle: Modulos de alto nivel no deben ser dependientes de modulos de bajo nivel. Hay un limite hasta donde te puedes abstraer. La abstraccion solo se aplica cuando hay dependencias volatiles (cambiables).
