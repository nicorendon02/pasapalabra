import 'dart:html';
import 'dart:collection';

class Rosco implements Resultado {
  ListQueue<Pregunta> roscoPreguntas = ListQueue<Pregunta>();
  List<String> respondidas = [];
  List<String> pasadas = [];
  int incorrectas = 0;
  int correctas = 0;
  int numPreguntas = 0;

  Rosco() {
    roscoPreguntas.addAll(RoscoApi().obtenerRoscos());
    numPreguntas = roscoPreguntas.length;
  }

  Pregunta obtenerPregunta(bool inicial) {
    if (inicial) return roscoPreguntas.first;

    var siguientePregunta = roscoPreguntas.firstWhere(
        (rosco) =>
            !respondidas.any((x) => x == rosco.letra) &&
            !pasadas.any((x) => x == rosco.letra),
        orElse: () => null);

    if (siguientePregunta == null) {
      if (_puedoResetearRosco()) {
        pasadas = [];
        return obtenerPregunta(false);
      } else {
        return roscoPreguntas.last;
      }
    }

    return siguientePregunta;
  }

  Pregunta pasapalabra(String letraActual) {
    var siguientePregunta = roscoPreguntas.firstWhere(
        (rosco) =>
            !(rosco.letra == letraActual) &&
            !pasadas.any((x) => x == rosco.letra) &&
            !respondidas.any((x) => x == rosco.letra),
        orElse: () => null);

    if (siguientePregunta == null) {
      if (_puedoResetearRosco()) {
        pasadas = [];
        return pasapalabra("");
      } else {
        return roscoPreguntas.last;
      }
    }

    pasadas.add(letraActual);
    return siguientePregunta;
  }

  String evaluarRespuesta(String letra, String respuesta) {
    var pregunta = roscoPreguntas.firstWhere((rosco) => rosco.letra == letra);

    respondidas.add(pregunta.letra);

    if (pregunta.respuesta == respuesta) {
      correctas++;

      return "Letra $letra respuesta correcta";
    }
    incorrectas++;
    return "Letra $letra respuesta incorrecta";
  }

  bool _puedoResetearRosco() {
    return roscoPreguntas
        .any((rosco) => !respondidas.any((x) => x == rosco.letra));
  }
}

class Pregunta {
  String letra;
  String definicion;
  String respuesta;

  Pregunta(this.letra, this.definicion, this.respuesta);
}

class Db {
  static List letras = const ["A", "B", "C", "D", "E", "F"];
  static List definiciones = const [
    "Persona que tripula una Astronave o que está entrenada para este Trabajo",
    "Especie de Talega o Saco de Tela y otro material que sirve para llevar o guardar algo",
    "Aparato destinado a registrar imágenes animadas para el cine o la telivision",
    "Obra literaria escrita para ser representada",
    "Que se prolonga muchisimo o excesivamente",
    "Laboratorio y despacho del farmaceutico"
  ];
  static List respuestas = [
    "Astronauta",
    "Bolsa",
    "Camara",
    "Drama",
    "Eterno",
    "Farmacia"
  ];
}

class RoscoApi {
  List<Pregunta> roscoPreguntas = [];

  List<Pregunta> obtenerRoscos() {
    for (var letra in Db.letras) {
      var index = Db.letras.indexOf(letra);
      var roscoPregunta =
          Pregunta(letra, Db.definiciones[index], Db.respuestas[index]);
      roscoPreguntas.add(roscoPregunta);
    }

    return roscoPreguntas;
  }
}

abstract class Resultado {
  int incorrectas;
  int correctas;
  int numPreguntas;
}

class RoscoEstado {
  bool continuar = true;
  bool continuarRosco(Resultado resultado) {
    _evaluarRosco(resultado.correctas == resultado.numPreguntas,
        "Ganaste el Rosco!!! Felicitaciones");
    _evaluarRosco(resultado.incorrectas == resultado.numPreguntas,
        "Se acabo el Rosco :(");
    _evaluarRosco(
        resultado.incorrectas + resultado.correctas == resultado.numPreguntas,
        "Se acabo el Rosco :(");

    return continuar;
  }

   void _evaluarRosco(bool condicion, mensaje) {
    if (condicion) {
      continuar = false;
      print(mensaje);
    }
  }
}

void main() {
  var rosco = Rosco();
  var primeraDefinicion = rosco.obtenerPregunta(true);

  querySelector("#pregunta").text = primeraDefinicion.definicion;
  querySelector("#letra").text = primeraDefinicion.letra;

  querySelector("#btnEnviar").onClick.listen((event) {
    var respuesta = (querySelector("#textRespuesta") as InputElement).value;
    var letra = querySelector("#letra").text;

    String mensaje = rosco.evaluarRespuesta(letra, respuesta);

    var roscoEstado = RoscoEstado();
    if (roscoEstado.continuarRosco(rosco)) {
      var nuevaPregunta = rosco.obtenerPregunta(false);
      actualizarUI(nuevaPregunta);

      print(mensaje);
    }else{
      deshabilitar();
    }
  });

  querySelector("#btnPasapalabra").onClick.listen((event) {
    var roscoEstado = RoscoEstado();
    if (roscoEstado.continuarRosco(rosco)) {
      var nuevaPregunta = rosco.pasapalabra(querySelector("#letra").text);
      actualizarUI(nuevaPregunta);
    }else{
      deshabilitar();
    }
  });
}

void actualizarUI(Pregunta pregunta) {
  querySelector("#letra").text = pregunta.letra;
  querySelector("#pregunta").text = pregunta.definicion;
  (querySelector("#textRespuesta") as InputElement).value = "";
}


void deshabilitar(){
  (querySelector("#btnEnviar") as ButtonElement).disabled = true;
  (querySelector("#btnPasapalabra") as ButtonElement).disabled = true;
}

