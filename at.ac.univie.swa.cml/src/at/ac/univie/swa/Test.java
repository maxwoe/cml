package at.ac.univie.swa;

public class Test {
	
	public Integer var;
	
	class Test2 {
		public void test2() {
			test1().getVar().doubleValue();
		}
	}
	
	public Test test1() {
		return new Test();
	}
	
	Integer getVar() {
		return var;
	}
}

