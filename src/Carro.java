public class Carro {
    private int velocidad;

    public Carro() {
        velocidad = 0;
    }

    public void acelerar() {
        velocidad += 10;
        System.out.println("El carro acelera. Velocidad actual: " + velocidad + " km/h");
    }

    public static void main(String[] args) {
        Carro miCarro = new Carro();
        miCarro.acelerar();
        miCarro.acelerar();
    }
}
