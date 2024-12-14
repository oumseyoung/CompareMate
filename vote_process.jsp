<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.DateTimeFormatter"%>
<%@ page import="java.time.LocalDate, java.time.LocalTime, java.time.LocalDateTime"%>
<%@ page contentType="application/json; charset=UTF-8" language="java" %>

<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("userId");
    int postId = Integer.parseInt(request.getParameter("post_id"));
    String[] optionValues = request.getParameterValues("options[]");

    String DB_URL = "jdbc:mysql://localhost:3306/compare_mate?useSSL=false&serverTimezone=UTC";
    String DB_USERNAME = "root";
    String DB_PASSWORD = "0000";

    Connection conn = null;
    PreparedStatement stmt = null;
    PreparedStatement checkStmt = null;
    PreparedStatement insertStmt = null;
    PreparedStatement deleteStmt = null;
    PreparedStatement postStmt = null;
    PreparedStatement optionIdStmt = null;
    ResultSet rs = null;
    ResultSet rsPost = null;
    ResultSet rsOptionId = null;

    StringBuilder json = new StringBuilder();
    json.append("{");

    if (userId == null) {
        json.append("\"status\":\"error\",");
        json.append("\"message\":\"로그인이 필요합니다.\"");
        json.append("}");
        out.print(json.toString());
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);

        String postQuery = "SELECT end_date, end_time, multi_select FROM posts WHERE post_id = ?";
        postStmt = conn.prepareStatement(postQuery);
        postStmt.setInt(1, postId);
        rsPost = postStmt.executeQuery();

        LocalDateTime endDateTime = null;
        boolean multiSelect = false;

        if (rsPost.next()) {
            java.sql.Date sqlEndDate = rsPost.getDate("end_date");
            java.sql.Time sqlEndTime = rsPost.getTime("end_time");
            multiSelect = rsPost.getBoolean("multi_select");

            if (sqlEndDate != null && sqlEndTime != null) {
                LocalDate localDate = sqlEndDate.toLocalDate();
                LocalTime localTime = sqlEndTime.toLocalTime();
                endDateTime = LocalDateTime.of(localDate, localTime);
            }
        } else {
            json.append("\"status\":\"error\",");
            json.append("\"message\":\"해당 게시글이 존재하지 않습니다.\"");
            json.append("}");
            out.print(json.toString());
            return;
        }

        // 종료시간 체크
        if (endDateTime != null) {
            LocalDateTime now = LocalDateTime.now();
            if (now.isAfter(endDateTime)) {
                json.append("\"status\":\"error\",");
                json.append("\"message\":\"투표가 종료되었습니다.\"");
                json.append("}");
                out.print(json.toString());
                return;
            }
        }

        // 기존 투표 삭제 (변경/취소 무조건 가능)
        String checkQuery = "SELECT COUNT(*) FROM votes WHERE user_id=? AND post_id=?";
        checkStmt = conn.prepareStatement(checkQuery);
        checkStmt.setString(1, userId);
        checkStmt.setInt(2, postId);
        rs = checkStmt.executeQuery();
        int voteCount = 0;
        if (rs.next()) {
            voteCount = rs.getInt(1);
        }

        if (voteCount > 0) {
            String deleteQuery = "DELETE FROM votes WHERE user_id=? AND post_id=?";
            deleteStmt = conn.prepareStatement(deleteQuery);
            deleteStmt.setString(1, userId);
            deleteStmt.setInt(2, postId);
            deleteStmt.executeUpdate();
        }

        if (!multiSelect && optionValues.length > 1) {
            json.append("\"status\":\"error\",");
            json.append("\"message\":\"복수 선택이 불가능한 투표입니다.\"");
            json.append("}");
            out.print(json.toString());
            return;
        }

        String optionIdQuery = "SELECT option_id, option_text FROM poll_options WHERE post_id=?";
        optionIdStmt = conn.prepareStatement(optionIdQuery);
        optionIdStmt.setInt(1, postId);
        rsOptionId = optionIdStmt.executeQuery();

        Map<String, Integer> optionMap = new HashMap<>();
        while(rsOptionId.next()) {
            optionMap.put(rsOptionId.getString("option_text"), rsOptionId.getInt("option_id"));
        }

        String insertQuery = "INSERT INTO votes (user_id, post_id, option_id) VALUES (?,?,?)";
        insertStmt = conn.prepareStatement(insertQuery);

        for (String val : optionValues) {
            if (optionMap.containsKey(val)) {
                insertStmt.setString(1, userId);
                insertStmt.setInt(2, postId);
                insertStmt.setInt(3, optionMap.get(val));
                insertStmt.addBatch();
            } else {
                json.append("\"status\":\"error\",");
                json.append("\"message\":\"선택한 옵션이 존재하지 않습니다.\"");
                json.append("}");
                out.print(json.toString());
                return;
            }
        }
        insertStmt.executeBatch();

        String resultQuery = "SELECT po.option_text, COUNT(v.option_id) as cnt " +
                             "FROM poll_options po LEFT JOIN votes v ON po.option_id = v.option_id " +
                             "WHERE po.post_id=? GROUP BY po.option_text ORDER BY po.option_id";
        stmt = conn.prepareStatement(resultQuery);
        stmt.setInt(1, postId);
        rs = stmt.executeQuery();

        json.append("\"status\":\"success\",");
        json.append("\"message\":\"투표가 완료되었습니다.\",");
        json.append("\"results\":[");
        boolean first = true;
        while(rs.next()) {
            if(!first) json.append(",");
            json.append("{");
            json.append("\"option_text\":\"" + rs.getString("option_text") + "\",");
            json.append("\"count\":" + rs.getInt("cnt"));
            json.append("}");
            first = false;
        }
        json.append("]}");

        out.print(json.toString());
    } catch (Exception e) {
        e.printStackTrace();
        json.setLength(0);
        json.append("{\"status\":\"error\",\"message\":\"서버 오류 발생\"}");
        out.print(json.toString());
    } finally {
        if(rs != null) try{ rs.close(); }catch(Exception ignore){}
        if(rsPost != null) try{ rsPost.close(); }catch(Exception ignore){}
        if(rsOptionId != null) try{ rsOptionId.close(); }catch(Exception ignore){}
        if(stmt != null) try{ stmt.close(); }catch(Exception ignore){}
        if(checkStmt != null) try{ checkStmt.close(); }catch(Exception ignore){}
        if(optionIdStmt != null) try{ optionIdStmt.close(); }catch(Exception ignore){}
        if(insertStmt != null) try{ insertStmt.close(); }catch(Exception ignore){}
        if(deleteStmt != null) try{ deleteStmt.close(); }catch(Exception ignore){}
        if(postStmt != null) try{ postStmt.close(); }catch(Exception ignore){}
        if(conn != null) try{ conn.close(); }catch(Exception ignore){}
    }
%>
