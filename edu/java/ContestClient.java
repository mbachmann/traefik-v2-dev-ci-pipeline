package ch.zhaw.solution.le07c.repetition;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class ContestClient {

	public void go() {

		try (Socket socket = new Socket("united-portal.com", 9998);
				BufferedReader reader = new BufferedReader(
				new InputStreamReader(socket.getInputStream()));) {

			String question = reader.readLine();
			System.out.println("Die Frage lautet: " + question);


		} catch (IOException e) {
			e.printStackTrace();
		}

		try (Socket socket2 = new Socket("united-portal.com", 9999);
			PrintWriter writer = new PrintWriter(socket2.getOutputStream()) ) {
			writer.print("Mbach Hier kommt dann Ihre Anwort");

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		new ContestClient().go();
	}

}

