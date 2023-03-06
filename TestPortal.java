public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();
   
         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)
         
         /*
          * TEST 1
          * listing info for student
          */
         prettyPrint(c.getInfo("9999999999")); 
         pause();

         /*
          * TEST 2
          * register a student for an unrestricted course and print the
          * infomation about the student to check that they are registered
          */
         System.out.println(c.register("9999999999", "CCC111"));
         prettyPrint(c.getInfo("9999999999"));
         pause();


         /*
          * TEST 3
          * Register the same student for the same course again
          */
         System.out.println(c.register("9999999999", "CCC111"));
         pause();


          /*
           * TEST 4
           * Unregister the student from the course, and then 
           * unregister him/her again from the same course. Check
           *  that the student is no longer registered and that
           *  the second unregistration gives an error response.
           */
         System.out.println(c.unregister("9999999999", "CCC111"));
         System.out.println(c.unregister("9999999999", "CCC111")); 
         prettyPrint(c.getInfo("9999999999"));
         pause();



           /*
           * TEST 5
           * Register the student for a course that he/she does not have
           *  the prerequisites for, and check that an error is generated.
           */
         System.out.println(c.register("9999999999", "CCC555"));
         pause();

           /*
           * TEST 6
           * Unregister a student from a restricted course that he/she is
           * registered to, and which has at least two students in the queue. 
           * Register the student again to the same course and check that the
           * student gets the correct (last) position in the waiting list.
           */



           /*
           * TEST 7
           * Unregister and re-register the same student for the same 
           * restricted course, and check that the student is first removed
           * and then ends up in the same position as before (last).
           */



           /*
           * TEST 8
           * Unregister a student from an overfull course, i.e. one
           * with more students registered than there are places on
           * the course (you need to set this situation up in the database
           * directly).  Check that no student was moved from the queue to 
           * being registered as a result.
           */



           /*
           * TEST 9
           * Unregister with the SQL injection you introduced, causing 
           * all (or almost all?) registrations to disappear
           */




            /* 
                     code that was in the file when we downloaded it
                     that i am to scared to remove lol

         System.out.println(c.unregister("2222222222", "CCC333")); 
         pause();

         
         System.out.println(c.register("2222222222", "CCC333")); 
         pause(); 
            */


      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.5.1.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }

   
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}
