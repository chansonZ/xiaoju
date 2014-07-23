package xiaoju.platform.storm.examples;

import backtype.storm.Config;
import backtype.storm.LocalCluster;
import backtype.storm.topology.TopologyBuilder;
import backtype.storm.tuple.Fields;
/**
 * ����˵���� ���һ��topology����ʵ�ֶ�һ����������ĵ��ʳ��ֵ�Ƶ�ʽ���ͳ�ơ� ����topology��Ϊ�������֣�
 * WordReader:����Դ�������͵����ı���¼�����ӣ� WordNormalizer:���𽫵����ı���¼�����ӣ��зֳɵ���
 * WordCounter:����Ե��ʵ�Ƶ�ʽ����ۼ�
 * 
 * 2013-8-26 ����5:59:06
 */

public class TopologyMain {

	/**
	 * @param args
	 *            �ļ�·��
	 */
	public static void main(String[] args) throws Exception {
		if (args.length != 1) {
			System.out.println("Usage: <input-file>");
			return;
		}
		// Storm���֧�ֶ����ԣ���JAVA�����´���һ�����ˣ���Ҫʹ��TopologyBuilder���й���
		TopologyBuilder builder = new TopologyBuilder();
		/*
		 * WordReader�࣬��Ҫ�ǽ��ı����ݶ���һ��һ�е�ģʽ ��ϢԴspout��Storm����һ��topology�������Ϣ�����ߡ�
		 * һ����˵��ϢԴ���һ���ⲿԴ��ȡ���ݲ�����topology���淢����Ϣ��tuple�� Spout�����ǿɿ���Ҳ�����ǲ��ɿ��ġ�
		 * ������tupleû�б�storm�ɹ�����
		 * ���ɿ�����ϢԴspouts�������·���һ��tuple�����ǲ��ɿ�����ϢԴspoutsһ������һ��tuple�Ͳ����ط��ˡ�
		 * 
		 * ��ϢԴ���Է��������Ϣ��stream��������Ϣ���������Ϊ�������͵����ݡ�
		 * ʹ��OutputFieldsDeclarer.declareStream��������stream
		 * ��Ȼ��ʹ��SpoutOutputCollector������ָ����stream��
		 * 
		 * Spout����������Ҫ�ķ�����nextTuple��Ҫô����һ���µ�tuple��topology������߼򵥵ķ�������Ѿ�û���µ�tuple��
		 * Ҫע�����nextTuple����������������Ϊstorm��ͬһ���߳��������������ϢԴspout�ķ�����
		 * 
		 * ���������Ƚ���Ҫ��spout������ack��fail��storm�ڼ�⵽һ��tuple������topology�ɹ������ʱ�����ack��
		 * �������fail��stormֻ�Կɿ���spout����ack��fail��
		 */
		builder.setSpout("word-reader", new WordReader());
		/*
		 * WordNormalizer�࣬��Ҫ�ǽ�һ��һ�е��ı������и�ɵ���
		 * 
		 * ���е���Ϣ�����߼�����װ��bolts���档Bolts�������ܶ����飺���ˣ��ۺϣ���ѯ���ݿ�ȵȡ�
		 * Bolts���Լ򵥵�����Ϣ���Ĵ��ݡ����ӵ���Ϣ������������Ҫ�ܶಽ�裬�Ӷ�Ҳ����Ҫ�����ܶ�bolts��
		 * �������һ��ͼƬ���汻ת������ͼƬ��������Ҫ������ ��һ�����ÿ��ͼƬ��ת��������
		 * �ڶ����ҳ�ת������ǰ10��ͼƬ�������Ҫ������������ø�������չ����ô������Ҫ����Ĳ��裩��
		 * 
		 * Bolts���Է��������Ϣ����
		 * ʹ��OutputFieldsDeclarer.declareStream����stream��ʹ��OutputCollector
		 * .emit��ѡ��Ҫ�����stream�� Bolts����Ҫ������execute,
		 * ����һ��tuple��Ϊ���룬boltsʹ��OutputCollector������tuple��
		 * bolts����ҪΪ�������ÿһ��tuple����OutputCollector��ack����
		 * ����֪ͨStorm���tuple����������ˣ��Ӷ�֪ͨ���tuple�ķ�����spouts�� һ��������ǣ�
		 * bolts����һ������tuple, ����0�����߶��tuple,
		 * Ȼ�����ack֪ͨstorm�Լ��Ѿ���������tuple�ˡ�storm�ṩ��һ��IBasicBolt���Զ�����ack��
		 */
		builder.setBolt("word-normalizer", new WordNormalizer())
				.shuffleGrouping("word-reader");
		/*
		 * ����Ĵ��������Ĵ����ж��趨�����ݷ���Ĳ���stream grouping
		 * ����һ��topology������һ���Ƕ���ÿ��bolt����ʲô��������Ϊ���롣stream
		 * grouping������������һ��streamӦ������������ݸ�bolts����Ķ��tasks�� Storm������7�����͵�stream
		 * grouping Shuffle Grouping: ������飬
		 * ����ɷ�stream�����tuple����֤ÿ��bolt���յ���tuple��Ŀ������ͬ�� Fields Grouping�����ֶη��飬
		 * ���簴userid�����飬 ����ͬ��userid��tuple�ᱻ�ֵ���ͬ��Bolts���һ��task��
		 * ����ͬ��userid��ᱻ���䵽��ͬ��bolts���task�� All
		 * Grouping���㲥���ͣ�����ÿһ��tuple�����е�bolts�����յ��� Global Grouping��ȫ�ַ��飬
		 * ���tuple�����䵽storm�е�һ��bolt������һ��task���پ���һ����Ƿ����idֵ��͵��Ǹ�task�� Non
		 * Grouping�������飬��stream grouping���������˼��˵stream�����ĵ���˭���յ�����tuple��
		 * Ŀǰ���ַ����Shuffle grouping��һ����Ч����
		 * ��һ�㲻ͬ����storm������bolt�ŵ����bolt�Ķ�����ͬһ���߳�����ȥִ�С� Direct Grouping�� ֱ�ӷ��飬
		 * ����һ�ֱȽ��ر�ķ��鷽���������ַ�����ζ����Ϣ�ķ�����ָ������Ϣ�����ߵ��ĸ�task���������Ϣ�� ֻ�б�����ΪDirect
		 * Stream����Ϣ�������������ַ��鷽��������������Ϣtuple����ʹ��emitDirect���������䡣
		 * ��Ϣ�����߿���ͨ��TopologyContext����ȡ����������Ϣ��task��id
		 * ��OutputCollector.emit����Ҳ�᷵��task��id���� Local or shuffle
		 * grouping�����Ŀ��bolt��һ�����߶��task��ͬһ�����������У�tuple���ᱻ�����������Щtasks��
		 * ���򣬺���ͨ��Shuffle Grouping��Ϊһ�¡�
		 */
		builder.setBolt("word-counter", new WordCounter(), 1).fieldsGrouping(
				"word-normalizer", new Fields("word"));

		/*
		 * storm������������ģʽ: ����ģʽ�ͷֲ�ʽģʽ. 1) ����ģʽ�� storm��һ������������߳���ģ�����е�spout��bolt.
		 * ����ģʽ�Կ����Ͳ�����˵�Ƚ����á� ������storm-starter�����topology��ʱ�����Ǿ����Ա���ģʽ���еģ�
		 * ����Կ���topology�����ÿһ������ڷ���ʲô��Ϣ�� 2) �ֲ�ʽģʽ��
		 * storm��һ�ѻ�����ɡ������ύtopology��master��ʱ�� ��ͬʱҲ��topology�Ĵ����ύ�ˡ�
		 * master����ַ���Ĵ��벢�Ҹ�������topolgoy���乤�����̡����һ���������̹ҵ��ˣ�
		 * master�ڵ�����Ϊ���·��䵽�����ڵ㡣 �������Ա���ģʽ���еĴ���:
		 * 
		 * Conf����������úܶණ���� ��������������ģ� TOPOLOGY_WORKERS(setNumWorkers)
		 * ������ϣ����Ⱥ������ٸ��������̸�����ִ�����topology.
		 * topology�����ÿ������ᱻ��Ҫ�߳���ִ�С�ÿ����������ö��ٸ��߳���ͨ��setBolt��setSpout��ָ���ġ�
		 * ��Щ�̶߳������ڹ�����������. ÿһ���������̰���һЩ�ڵ��һЩ�����̡߳� ���磬 �����ָ��300���̣߳�60�����̣�
		 * ��ôÿ��������������Ҫִ��6���̣߳� ����6���߳̿������ڲ�ͬ�����(Spout, Bolt)��
		 * �����ͨ������ÿ������Ĳ��ж��Լ���Щ�߳����ڵĽ�������������topology�����ܡ� TOPOLOGY_DEBUG(setDebug),
		 * ���������ó�true�Ļ��� storm���¼��ÿ������������ÿ����Ϣ�� ���ڱ��ػ�������topology�����ã�
		 * ������������ô���Ļ���Ӱ�����ܵġ�
		 */
		Config conf = new Config();
		conf.setDebug(true);
		conf.setNumWorkers(2);
		conf.put("wordsFile", args[0]);
		conf.setMaxSpoutPending(10);
		conf.setNumAckers(2);
		/*
		 * ����һ��LocalCluster����������һ�������ڵļ�Ⱥ���ύtopology���������ļ�Ⱥ���ύtopology���ֲ�ʽ��Ⱥ��һ���ġ�
		 * ͨ������submitTopology�������ύtopology��
		 * ����������������Ҫ���е�topology�����֣�һ�����ö����Լ�Ҫ���е�topology����
		 * topology������������Ψһ����һ��topology�ģ�������Ȼ����������������ɱ�����topology�ġ�ǰ���Ѿ�˵���ˣ�
		 * �������ʽ��ɱ��һ��topology�� ��������һֱ���С�
		 */
		
		LocalCluster cluster = new LocalCluster();
		cluster.submitTopology("wordCounterTopology", conf,
				builder.createTopology());
		try {
			Thread.sleep(20000);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		cluster.killTopology("wordCounterTopology");
		cluster.shutdown();
	}

}