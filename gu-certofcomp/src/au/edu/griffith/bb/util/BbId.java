package au.edu.griffith.bb.util;

import java.lang.reflect.Constructor;

import blackboard.persist.DataType;
import blackboard.persist.Id;
import blackboard.persist.PersistenceException;

public class BbId
{

  private Id id;

  private String idString;

  private String pkString;

  private Integer pk;

  private BbId()
  {
    id = null;
    idString = null;
    pkString = null;
    pk = null;
  }

  public static <T extends Exception> BbId fromId(Id id, Class<T> exceptionClass, String message) throws T, InstantiationException
  {
    try
    {
      BbId bbId = new BbId();
      bbId.id = id;
      bbId.idString = bbId.id.toExternalString();
      bbId.pkString = bbId.idString.substring(1, bbId.idString.length() - 2);
      bbId.pk = Integer.parseInt(bbId.pkString);
      return bbId;
    }
    catch (Exception e)
    {
      try
      {
        Constructor<T> constructor = exceptionClass.getConstructor(new Class[] { String.class });
        T t = constructor.newInstance(new Object[] { message + " - " + e.getMessage() });
        throw t;
      }
      catch (Exception ee)
      {
        throw new InstantiationException(message + " - " + e.getMessage());
      }
    }
  }

  public static <T extends Exception> BbId fromIdString(String idString, Class<T> exceptionClass, String message) throws T, InstantiationException
  {
    try
    {
      BbId bbId = new BbId();
      bbId.idString = idString;
      bbId.pkString = bbId.idString.substring(1, bbId.idString.length() - 2);
      bbId.pk = Integer.parseInt(bbId.pkString);
      return bbId;
    }
    catch (Exception e)
    {
      try
      {
        Constructor<T> constructor = exceptionClass.getConstructor(new Class[] { String.class });
        T t = constructor.newInstance(new Object[] { message + " - " + e.getMessage() });
        throw t;
      }
      catch (Exception ee)
      {
        throw new InstantiationException(message + " - " + e.getMessage());
      }
    }
  }

  public static <T extends Exception> BbId fromPkString(String pkString, Class<T> exceptionClass, String message) throws T, InstantiationException
  {
    try
    {
      BbId bbId = new BbId();
      bbId.pkString = pkString;
      bbId.pk = Integer.parseInt(bbId.pkString);
      return bbId;
    }
    catch (Exception e)
    {
      try
      {
        Constructor<T> constructor = exceptionClass.getConstructor(new Class[] { String.class });
        T t = constructor.newInstance(new Object[] { message + " - " + e.getMessage() });
        throw t;
      }
      catch (Exception ee)
      {
        throw new InstantiationException(message + " - " + e.getMessage());
      }
    }
  }

  public static BbId fromPk(int pk)
  {
    BbId bbId = new BbId();
    bbId.pk = pk;
    return bbId;
  }

  public void generateId(DataType type) throws PersistenceException
  {
    id = Id.generateId(type, pk);
    idString = id.toExternalString();
    pkString = idString.substring(1, idString.length() - 2);
  }

  /**
   * @return the id
   */
  public Id getId()
  {
    return id;
  }

  /**
   * @return the idString
   */
  public String getIdString()
  {
    return idString;
  }

  /**
   * @return the pkString
   */
  public String getPkString()
  {
    return pkString;
  }

  /**
   * @return the pk
   */
  public Integer getPk()
  {
    return pk;
  }

}
