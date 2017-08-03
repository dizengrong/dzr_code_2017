package dzr.java_demo;

public class Fund implements java.io.Serializable {

    private int id;
    private int sort;
    private int uid;
    private String fetched_list;
    
    public Fund() {
    }

    public Fund(int id, int sort, int uid, String fetched_list) {
        this.id = id;
        this.sort = sort;
        this.uid = uid;
        this.fetched_list = fetched_list;
    }
    
    public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getSort() {
		return sort;
	}

	public void setSort(int sort) {
		this.sort = sort;
	}

	public int getUid() {
		return uid;
	}

	public void setUid(int uid) {
		this.uid = uid;
	}

	public String getFetched_list() {
		return fetched_list;
	}

	public void setFetched_list(String fetched_list) {
		this.fetched_list = fetched_list;
	}

}