# Notas derivadas de Web Dev Simplified

- Headers ahora son async: es una optimizacion para el renderizado, lo mismo para searchParams, params y cookies. Todos van a requerir que se use await.
- Fetch request no seran cacheadas por defecto como antes, es necesario colocar {cache:'force-cache'}, la otra opcion es 'no-store' y es la que viene por defecto.
- La nueva configuracion default del cache se puede modificar para fetch calls simples, para toda una ruta o para todo un layout. Eso otorga otro nivel de flexibilidad y decision.
- GET route handlers tampoco van a ser cacheadas por defecto. Mejor asi.
- Client router cache tampoco sera default. Positivo para ver los cambios en tiempo real.
- Para usar turbo pack para el npm run dev, se puede agregar --turbo al script dev en el package.json, hace la experiencia de desarrollo mas veloz y mas agradable.
- Agrega una senhalizacion para ver cuales paginas son estaticas y cuales son dinamicas.
- Ahora tenemos un Form component.
- Typescript support, ya lo tenia, pero bueno.
- Server actions al ser una api publica pueden ser abusadas por terceros. Debido a esto nextjs en su version 15 ahora obscurece un poco el codigo para que no se note.

---
