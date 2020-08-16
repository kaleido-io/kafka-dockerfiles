package se.repos.substitutions.kafka.zookeeper;

import com.oracle.svm.core.annotate.Substitute;
import com.oracle.svm.core.annotate.TargetClass;

import org.apache.zookeeper.jmx.ZKMBeanInfo;

import java.util.HashSet;
import java.util.Set;

import javax.management.JMException;

/*
zoo-2_1     | [QuorumPeer[myid=3](plain=0.0.0.0:2181)(secure=disabled)] WARN org.apache.zookeeper.server.ZooKeeperServer - Failed to register with JMX
zoo-2_1     | java.lang.NullPointerException
zoo-2_1     | 	at org.apache.zookeeper.jmx.MBeanRegistry.register(MBeanRegistry.java:108)
zoo-2_1     | 	at org.apache.zookeeper.server.quorum.LearnerZooKeeperServer.registerJMX(LearnerZooKeeperServer.java:105)
zoo-2_1     | 	at org.apache.zookeeper.server.ZooKeeperServer.startup(ZooKeeperServer.java:461)
zoo-2_1     | 	at org.apache.zookeeper.server.quorum.Learner.syncWithLeader(Learner.java:572)
zoo-2_1     | 	at org.apache.zookeeper.server.quorum.Follower.followLeader(Follower.java:89)
zoo-2_1     | 	at org.apache.zookeeper.server.quorum.QuorumPeer.run(QuorumPeer.java:1253)
zoo-2_1     | 	at com.oracle.svm.core.thread.JavaThreads.threadStartRoutine(JavaThreads.java:517)
zoo-2_1     | 	at com.oracle.svm.core.posix.thread.PosixJavaThreads.pthreadStartRoutine(PosixJavaThreads.java:193)
*/

@TargetClass(org.apache.zookeeper.jmx.MBeanRegistry.class)
final class NoJMX {

  @Substitute
  public void register(ZKMBeanInfo bean, ZKMBeanInfo parent)
  	throws JMException {
  }

  @Substitute
  private void unregister(String path,ZKMBeanInfo bean) throws JMException  {
  }

  @Substitute
  public Set<ZKMBeanInfo> getRegisteredBeans() {
	return new HashSet<>();
  }

  @Substitute
  public void unregister(ZKMBeanInfo bean) {
  }



}
