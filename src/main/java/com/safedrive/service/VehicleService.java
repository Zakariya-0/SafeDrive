package com.safedrive.service;

import com.safedrive.dao.VehicleDAO;
import com.safedrive.model.Vehicle;
import com.safedrive.model.VehicleStatus;

import java.util.List;
import java.util.Optional;

public class VehicleService {

    private final VehicleDAO dao = new VehicleDAO();

    public Vehicle createVehicle(String regNumber, String brand, String model,
                                  Integer year, Integer mileage) {
        Vehicle v = new Vehicle();
        v.setRegistrationNumber(regNumber);
        v.setBrand(brand);
        v.setModel(model);
        v.setYear(year);
        v.setMileage(mileage != null ? mileage : 0);
        v.setStatus(VehicleStatus.AVAILABLE);
        return dao.save(v);
    }

    public Vehicle updateVehicle(Vehicle vehicle)       { return dao.save(vehicle); }
    public void deleteVehicle(Long id)                  { dao.delete(id); }
    public Optional<Vehicle> findById(Long id)          { return dao.findById(id); }
    public List<Vehicle> getAllVehicles()                { return dao.findAll(); }
    public List<Vehicle> getAvailableVehicles()         { return dao.findByStatus(VehicleStatus.AVAILABLE); }
    public List<Vehicle> getVehiclesWithoutChauffeur()  { return dao.findAvailable(); }
    public Optional<Vehicle> getVehicleByDriverId(Long driverId) { return dao.findByDriverId(driverId); }
    public long countTotal()                            { return dao.count(); }
    public long countByStatus(VehicleStatus s)          { return dao.countByStatus(s); }

    public void assignChauffeur(Long vehicleId, Long chauffeurId) {
        dao.assignChauffeur(vehicleId, chauffeurId);
    }

    public void unassignChauffeur(Long vehicleId) {
        dao.unassignChauffeur(vehicleId);
    }
}
