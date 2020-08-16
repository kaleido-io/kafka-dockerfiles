package se.repos.substitutions.kafka.admincmd;

import com.oracle.svm.core.annotate.Substitute;
import com.oracle.svm.core.annotate.TargetClass;

/*
Call path from entry point to kafka.metrics.KafkaYammerMetrics.defaultRegistry(): 
	at kafka.metrics.KafkaYammerMetrics.defaultRegistry(KafkaYammerMetrics.java:44)
	at kafka.metrics.KafkaMetricsGroup.removeMetric(KafkaMetricsGroup.scala:80)
	at kafka.metrics.KafkaMetricsGroup.removeMetric$(KafkaMetricsGroup.scala:79)
	at kafka.zk.KafkaZkClient.removeMetric(KafkaZkClient.scala:53)
	at kafka.zk.KafkaZkClient.close(KafkaZkClient.scala:1450)
	at kafka.admin.TopicCommand$ZookeeperTopicService.close(TopicCommand.scala:507)
	at kafka.admin.TopicCommand$.main(TopicCommand.scala:77)
	at kafka.admin.TopicCommand.main(TopicCommand.scala)
	at com.oracle.svm.core.JavaMainWrapper.runCore(JavaMainWrapper.java:149)
	at com.oracle.svm.core.JavaMainWrapper.run(JavaMainWrapper.java:184)
	at com.oracle.svm.core.code.IsolateEnterStub.JavaMainWrapper_run_5087f5482cc9a6abc971913ece43acb471d2631b(generated:0)

	at com.oracle.graal.pointsto.constraints.UnsupportedFeatures.report(UnsupportedFeatures.java:129)
	at com.oracle.svm.hosted.NativeImageGenerator.runPointsToAnalysis(NativeImageGenerator.java:750)
	... 8 more
*/

//import scala.collection.Map;
import java.util.Map;

/*
import com.yammer.metrics.core.MetricsRegistry;

@TargetClass(className = "scala.collection.immutable.VM")
class JMX {

  @Substitute
  public static MetricsRegistry defaultRegistry() {
    return null;
  }

}
*/

@TargetClass(className = "kafka.metrics.KafkaMetricsGroup")
final class NoJMX {

  @Substitute
  public void removeMetric(String name, Map<String, String> tags) {
  }

}
