package ch.zhaw.solution.le07c.repetition;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class ContestQuestionServer {

	private int hits;
	private static final int PORT_NUMBER = 9998;

	public void startQuestionServer() {
		try (ServerSocket serverSocket = new ServerSocket(PORT_NUMBER);) {
			while(true) {
				try  (Socket socket = serverSocket.accept();){
					answerQuestion (socket);
				} catch (IOException e) {
					System.out.println("Autsch: " + e.getMessage());
				}
			}
		} catch (IOException e1) {
			e1.printStackTrace();
			System.exit(0);
		}
	}

	void answerQuestion(Socket socket) {

		hits ++;
		try (PrintWriter writer = new PrintWriter(socket.getOutputStream());) {
			writer.println("Was macht die Methode \"accept()\" " + "der Klasse \"ServerSocket\"?");
			System.out.println("Zugriffe: " + hits);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	public static void main(String[] args) {
		System.out.println(ContestQuestionServer.class.getName() + " started");
		System.out.println("Listening to " + PORT_NUMBER);

		new ContestQuestionServer().startQuestionServer();
	}
}
