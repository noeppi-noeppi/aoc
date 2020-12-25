import scala.io.StdIn

object Part1 extends App {
  
  val publicCard = StdIn.readLine().toLong
  val publicDoor = StdIn.readLine().toLong
  
  val loopCard = loopValue(publicCard, 7)
  val loopDoor = loopValue(publicDoor, 7)
  
  val key = transform(publicCard, loopDoor)
  println(key)
  
  def loopValue(public: Long, subject: Long): Int = {
    var value = 1L
    var loop = 0
    while (value != public) {
      loop += 1
      value = (value * subject) % 20201227
    }
    loop
  }
  
  def transform(subject: Long, loop: Int): Long = {
    var value = 1L
    for (_ <- 0 until loop) {
      value = (value * subject) % 20201227
    }
    value
  }
}