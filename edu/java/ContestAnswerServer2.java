
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;

public class ContestAnswerServer2 {
	private int hits;
	private static final int BUFFER_SIZE = 1000;
	private static final int PORT_NUMBER = 9999;

	public void startAnswerServer() {
		try (ServerSocket serverSocket = new ServerSocket(PORT_NUMBER)){

			while(true) {
				Socket socket = null;
				try {
					socket = serverSocket.accept();
					socket.setSoTimeout(100);
					// der read-Aufruf auf dem input-stream blockiert nur 0.1 Sekunden. Falls in dieser
					// Zeit nichts gelesen werden kann (weil nichts geschickt wird)
					// wird eine java.net.SocketTimeoutException geworfen.
					// (siehe auch javadoc)
				} catch (IOException e) {
					System.out.println("Autsch: " + e.getMessage());
				}

				try  (BufferedReader reader = new BufferedReader(
						new InputStreamReader(socket.getInputStream()))) {
					hits++;

					char[] charBuffer = new char[BUFFER_SIZE];
					int zeichen = reader.read(charBuffer, 0, BUFFER_SIZE);

					if (zeichen >= BUFFER_SIZE) {
						System.out.println("He! Schick nicht soviele Zeichen! Es werden nur " + BUFFER_SIZE + " zeichen akzeptiert!");
					} else if (zeichen == -1){
						System.out.println("Du musst was schicken!");
					} else {
						System.out.println(hits + ": " + String.valueOf(charBuffer, 0, zeichen));
					}

				} catch (IOException e) {
					// catch try new BufferedReader()
					System.out.println("Autsch: " + e.getMessage());
				}
			} // while
		} catch (IOException e1) {
			// catch try new ServerSocket(9999)
			e1.printStackTrace();
			System.exit(0);
		}
	}

	public static void main(String[] args) {
		System.out.println(ContestAnswerServer2.class.getName() + " started");
		System.out.println("Listening to " + PORT_NUMBER);
		new ContestAnswerServer2().startAnswerServer();
	}
}
