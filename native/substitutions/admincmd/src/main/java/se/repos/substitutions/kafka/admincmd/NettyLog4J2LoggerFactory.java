package se.repos.substitutions.kafka.admincmd;

import com.oracle.svm.core.annotate.Substitute;
import com.oracle.svm.core.annotate.TargetClass;

import io.netty.util.internal.logging.InternalLogger;

@TargetClass(io.netty.util.internal.logging.Log4J2LoggerFactory.class)
final public class NettyLog4J2LoggerFactory {
    
  @Substitute
  public InternalLogger newInstance(String name) {
    // InternalLogger is an interface so if needed we could return a stub
    throw new UnsupportedOperationException("Log4J2 unsupported in native-image builds, see https://github.com/solsson/dockerfiles/pull/31");
  }

}
