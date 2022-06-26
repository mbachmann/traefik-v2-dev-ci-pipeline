

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class TippDesTagesServer {
    String[] tippListe = {
            "Nehmen Sie kleinere Bissen zu sich.",
            "Holen Sie sich die engen Jeans. Nein, Sie sehen darin NICHT dick aus.",
            "Mit einem Wort: unmoeglich!",
            "Seien Sie ehrlich, nur heute mal. Sagen Sie Ihrem Boss, was Sie *wirklich* denken.",
            "Vielleicht wollen Sie doch noch mal über diesen Haarschnitt nachdenken."
    };

    public static void main(String[] args) {
        new TippDesTagesServer().start();
    }

    public void start() {
        System.out.println("Server gestartet");

        try (ServerSocket serverSock = new ServerSocket(4242)) {
            while (true) {
                Socket sock = serverSock.accept();
                PrintWriter writer = new PrintWriter(sock.getOutputStream());
                String tipp = getTipp();
                writer.println(tipp);
                writer.close();
                System.out.println(tipp);
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    private String getTipp() {
        return tippListe[(int) (tippListe.length * Math.random())];
    }
}
