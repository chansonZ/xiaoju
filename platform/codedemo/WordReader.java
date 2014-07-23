package xiaoju.platform.storm.examples;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import kafka.consumer.ConsumerConfig;
import kafka.consumer.ConsumerIterator;
import kafka.consumer.KafkaStream;
import kafka.javaapi.consumer.ConsumerConnector;
import backtype.storm.spout.SpoutOutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseRichSpout;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Values;

/**
 * ServerSocket ����˵���� ��Ҫ�ǽ��ļ����ݶ�������һ��һ��
 * 
 * Spout����������Ҫ�ķ�����nextTuple�� Ҫô����һ���µ�tuple��topology������߼򵥵ķ�������Ѿ�û���µ�tuple��
 * Ҫע�����nextTuple����������������Ϊstorm��ͬһ���߳��������������ϢԴspout�ķ�����
 * ���������Ƚ���Ҫ��spout������ack��fail�� storm�ڼ�⵽һ��tuple������topology�ɹ������ʱ�����ack���������fail��
 * stormֻ�Կɿ���spout����ack��fail��
 * 
 */
public class WordReader extends BaseRichSpout {

	private SpoutOutputCollector collector;

	private ConsumerConnector consumer;
	private String topic;

	private static ConsumerConfig createConsumerConfig() {
		Properties props = new Properties();
		props.put("zookeeper.connect", "10.10.10.150:2181");
		props.put("group.id", "1");
		props.put("zookeeper.session.timeout.ms", "10000");

		// props.put("zookeeper.sync.time.ms", "200");
		// props.put("auto.commit.interval.ms", "1000");

		return new ConsumerConfig(props);

	}

	// storm�ڼ�⵽һ��tuple������topology�ɹ������ʱ�����ack���������fail��
	public void ack(Object msgId) {
		System.out.println("OK:" + msgId);
	}

	public void close() {
	}

	// storm�ڼ�⵽һ��tuple������topology�ɹ������ʱ�����ack���������fail��
	public void fail(Object msgId) {
		System.out.println("FAIL:" + msgId);
	}

	/*
	 * ��SpoutTracker���б����ã�ÿ����һ�ξͿ�����storm��Ⱥ�з���һ�����ݣ�һ��tupleԪ�飩���÷����ᱻ��ͣ�ĵ���
	 */
	public void nextTuple() {

		Map<String, Integer> topickMap = new HashMap<String, Integer>();
		topickMap.put(topic, 1);
		Map<String, List<KafkaStream<byte[], byte[]>>> streamMap = consumer
				.createMessageStreams(topickMap);
		KafkaStream<byte[], byte[]> stream = streamMap.get(topic).get(0);
		ConsumerIterator<byte[], byte[]> it = stream.iterator();
		while (it.hasNext()) {
			collector.emit(new Values(it.next().message().toString()));
		}

	}

	public void open(Map conf, TopologyContext context,
			SpoutOutputCollector collector) {

		this.collector = collector;
		topic = "kafka";
		consumer = kafka.consumer.Consumer
				.createJavaConsumerConnector(createConsumerConfig());
	}

	/**
	 * �����ֶ�id����id�ڼ�ģʽ��û���ô������ڰ����ֶη����ģʽ���кܴ���ô���
	 * ��declarer�����кܴ����ã����ǻ����Ե���declarer.
	 * declareStream();������stramId����id��������������Ӹ��ӵ������˽ṹ
	 */
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("line"));
	}
}