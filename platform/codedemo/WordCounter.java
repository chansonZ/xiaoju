package xiaoju.platform.storm.examples;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Map;






import backtype.storm.task.TopologyContext;
import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Tuple;

/**
 * 
 * ����˵���� ʵ�ּ������Ĺ��ܣ���һ�ν�collector�е�Ԫ�ش���ڳ�Ա����counters��Map����.
 * ���counters��Map�����Ѿ����ڸ�Ԫ�أ�getValule����Value�����ۼӲ�����
 * 
 */
public class WordCounter extends BaseBasicBolt {

	private static final long serialVersionUID = 5678586644899822142L;
	Integer id;
	String name;
	private String outFile;
	private BufferedWriter bw;
	
	Connection conn;
	Statement statement;

	/**
	 * ��spout����ʱ�����ã������Ľ����ʾ����
	 * 
	 * �Y��: -- Word Counter [word-counter-2] -- really: 1 but: 1 application: 1
	 * is: 2 great: 2
	 */
	@Override
	public void cleanup() {
		try {
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} 
	}

	/**
	 * ��ʼ������
	 */
	@Override
	public void prepare(Map stormConf, TopologyContext context) {
		this.name = context.getThisComponentId();
		this.id = context.getThisTaskId();
		
		String driver="com.mysql.jdbc.Driver";
		String url="jdbc:mysql://hdp998.jx:3377/data";
		String user="data_w";
		String pass="data_w";
		try{
			Class.forName(driver);
			conn=DriverManager.getConnection(url,user,pass);
			if(conn.isClosed())
				throw new Exception("Mysql getConnection ERROR!");
				
			statement=conn.createStatement();
			
			if( statement == null )
				throw new Exception("statement is null");
			
		}catch( Exception e)
		{
			e.printStackTrace();
		}

	}

	public void declareOutputFields(OutputFieldsDeclarer declarer) {
	}

	/**
	 * ʵ�ּ������Ĺ��ܣ���һ�ν�collector�е�Ԫ�ش���ڳ�Ա����counters��Map����.
	 * ���counters��Map�����Ѿ����ڸ�Ԫ�أ�getValule����Value�����ۼӲ�����
	 */
	public void execute(Tuple input, BasicOutputCollector collector) {
		String str = input.getString(0);
		
		String sql=String.format("insert into storm_bolt_ret (str) values ('%s')", str+"!");
		try {
			statement.executeQuery(sql);
			statement.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}