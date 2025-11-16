ActiveRecord Notes:

El metodo **merge** de active record te permite fusionar busquedas relacionadas entre modelos cuyos metodos esten en modelos diferentes, ejemplo:

```ruby

class Person < ActiveRecord::Base
  belongs_to :role

    def self.billable
    joins(:role).merge(Role.billable)
  end
end

class Role < ActiveRecord::Base
  has_many :people

    def self.billable
    where(billable: true)
  end
end

```

Esto permite pasar para todo el query, un solo metodo que seria:

```ruby
Person.billable
```

El metodo **from** permite hacer subconsultas (sub-queries) dentro de active record.

Nota importante, los joins y order by tambien aceptan AND y OR para gregar otras condiciones.
