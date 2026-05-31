import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class InsertUser {
    public static void main(String[] args) {
        String url = "jdbc:mysql://192.168.1.6:13306/invoicing_auth?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=false";
        String user = "root";
        String password = "root";
        
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String encodedPassword = encoder.encode("admin123");
        
        System.out.println("Encoded password: " + encodedPassword);
        
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            String sql = "INSERT INTO sys_user (tenant_id, username, password, nickname, email, phone, status) VALUES (1, ?, ?, ?, ?, ?, 1)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "admin");
            pstmt.setString(2, encodedPassword);
            pstmt.setString(3, "System Admin");
            pstmt.setString(4, "admin@test.com");
            pstmt.setString(5, "13800138000");
            pstmt.executeUpdate();
            System.out.println("User inserted successfully");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
