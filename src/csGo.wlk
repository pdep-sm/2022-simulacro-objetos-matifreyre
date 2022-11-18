class Jugador {
	const avatares = []
	var dinero = 800
	const historialDeCompras = []
	
	/** Punto 1.a */
	method killsTotales() = 
		avatares.sum{ avatar => avatar.cantidadJugadoresEliminados() }

	/** Punto 1.b */
	method muertesTotales() = 
		avatares.count{ avatar => avatar.murio() }
		
	/** Punto 1.c */
	method eficiencia() = 
		0.max(self.killsTotales() - self.muertesTotales())

	/** Punto 3 */
	method comprar(items) {
		const costo = items.sum{ item => item.costo() }
		self.validarCompra(costo)
		dinero -= costo
		self.ultimoAvatar().agregarItems(items)
	}
	
	method validarCompra(costo) {
		if (costo > dinero)
			throw new DomainException(message = "Dinero insuficiente")
	}
	
	method ultimoAvatar() = avatares.last()
	
	method nuevoAvatar() {
		const avatar = 
			if(avatares.isEmpty())
				self.primerAvatar()
			else {
				self.actualizarDinero()
				self.siguienteAvatar()	
			}
		avatares.add(avatar)
		return avatar
	}
	
	method actualizarDinero() {
		const premio = self.ultimoAvatar().eficiencia() * 800
		dinero += 800.max(premio).min(3500)
	}
	
	method primerAvatar() = new Avatar(jugador = self)
	
	method siguienteAvatar() =
		self.ultimoAvatar().siguienteAvatar()
		
	method realizarCompra(compra) {
		self.comprar(compra.items())
		historialDeCompras.add(compra)
	}
	
	method totalGastado() = 
		historialDeCompras.sum{ compra => compra.costo() }
}

class Avatar {
	const eliminados = #{ }
	var property sobrevivio = true
	const equipamiento = [armaReglamentaria]
	const property jugador
	
	method cantidadJugadoresEliminados() = 
		eliminados.size()
		
	method murio() = not sobrevivio
	
	method agregarItems(items) {
		equipamiento.addAll(items)
	}
	
	method siguienteAvatar() =
		if (sobrevivio)
			new Avatar(
				jugador = jugador, 
				equipamiento = equipamiento
			)
		else
			new Avatar(jugador = jugador)
			
	method eficiencia() =
		self.cantidadJugadoresEliminados() - 
		self.muertes()
		
	method muertes() = if (sobrevivio) 0 else 1
}

class Enfrentamiento {
	const property jugadores = #{}
	const partidas = []
	
	/** Punto 2 */
	method mvp() =
		self.jugadores().max{ jugador => jugador.eficiencia() }
		
	method crearPartida() {
		partidas.add(new Partida(
			avatares = self.nuevosAvatares()
		))
	}
	
	method nuevosAvatares() =
		jugadores.map{ jugador => jugador.nuevoAvatar() }
}

class Partida {
	const avatares
	
	method afectar(compras) {
		compras.forEach{ compra => compra.realizar() }
	}
}

class Equipamiento {
	const property costo
}

const armaReglamentaria = new Equipamiento(costo = 0)

class Compra {
	const property items = []
	const property jugador
	
	method realizar() {
		jugador.realizarCompra(self)
	}
	
	method costo() =
		items.sum{ item => item.costo() }
}