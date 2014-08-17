Permission.create(section: 'ticketing', resource: 'admin', action: 'login')

Permission.create(section: 'ticketing', resource: 'queue', action: 'read')
Permission.create(section: 'ticketing', resource: 'queue', action: 'create')
Permission.create(section: 'ticketing', resource: 'queue', action: 'update')
Permission.create(section: 'ticketing', resource: 'queue', action: 'destroy')

Permission.create(section: 'ticketing', resource: 'case', action: 'read')
Permission.create(section: 'ticketing', resource: 'case', action: 'create')
Permission.create(section: 'ticketing', resource: 'case', action: 'update')
Permission.create(section: 'ticketing', resource: 'case', action: 'destroy')
Permission.create(section: 'ticketing', resource: 'case', action: 'reassign')