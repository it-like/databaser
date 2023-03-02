
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "MyLike";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
      try(PreparedStatement st = conn.prepareStatement("INSERT INTO Registrations VALUES (?,?)"
        );){
       st.setString(1, student);
       st.setString(2, courseCode);
       st.executeUpdate();
      }
     catch (SQLException e) {
         return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
     }     
     return "{\"success\":true}";
    }
    

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){

      try(PreparedStatement st = conn.prepareStatement("DELETE FROM Registrations WHERE student = ? AND course = ?"
        );){
       st.setString(1, student);
       st.setString(2, courseCode);
       int deletedRows = st.executeUpdate();
       if (deletedRows == 0) {
        throw new SQLException();
      }
       st.executeUpdate();
      }
     catch (SQLException e) {
         return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
     }     
     return "{\"success\":true}";
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
          "SELECT jsonb_build_object('student', idnr, 'name', name, 'login', login, 'program', program, 'branch', branch, "+
          "'finished', (SELECT COALESCE(json_agg(jsonb_build_object('code', FinishedCourses.course, 'course', Courses.courseName, 'credits', Courses.credits, 'grade', FinishedCourses.grade)), null) FROM FinishedCourses INNER JOIN Courses ON FinishedCourses.course = Courses.code WHERE FinishedCourses.student = idnr), " +
          "'registered', (SELECT COALESCE(json_agg(jsonb_build_object('code', course, 'course', courseName, 'status', status)), null) FROM Registrations INNER JOIN Courses ON Registrations.course = Courses.code WHERE Registrations.student = idnr), " +
          "'seminarCourses', (SELECT seminarCourses FROM PathToGraduation WHERE student = idnr),"+
          "'mathCredits',(SELECT COUNT(PassedCourses.course) AS sumMath FROM PassedCourses, Classified WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'math' AND PassedCourses.student = BasicInformation.idnr), " +
          "'researchCredits', (SELECT COUNT(PassedCourses.course) AS sumResearch FROM PassedCourses, Classified WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'research' AND PassedCourses.student = BasicInformation.idnr), " +
          "'totalCredits',(SELECT SUM(credits) AS totCredits FROM PassedCourses WHERE PassedCourses.student = BasicInformation.idnr), "+
          "'canGraduate', (SELECT qualified FROM PathToGraduation WHERE student = idnr)"+
          ") AS jsondata FROM BasicInformation WHERE idnr = ?;"
            );){
            
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}


