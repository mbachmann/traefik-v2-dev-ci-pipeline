package ch.teko.le04.task05;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;

public class TippDesTagesClient {

    public static void main(String[] args) {
        try (Socket s = new Socket("united-portal.com", 4242)) {
            InputStreamReader streamReader = new InputStreamReader(s.getInputStream());
            BufferedReader reader = new BufferedReader(streamReader);
            String advice = reader.readLine();
            System.out.println("Ratschlag fuer heute: " + advice);
            reader.close();
        } catch(IOException ex) {
            ex.printStackTrace();
        }
    }


}
